const express = require('express');
const crypto = require('crypto');
const router = express.Router();

const logger = require('../utils/logger')
const log = logger(module.filename)

const pgPool = require('../pgpool').getPool();
const config = require('../config');
const {sendEmail} = require('../utils/mail-service')
const {getAuthorizationUrl, getLogoutUrl, formatUtilisateur} = require('../utils/utils')
const bodyParser = require('body-parser');
var moment = require('moment');
const { oauthCallback } = require('../controllers/oauthCallback')
const { pwdLogin } = require('../controllers/pwdLogin')
moment().format();


router.get('/login', (req, res) => {
    log.i('::login via France Connect')
    return res.send({url: getAuthorizationUrl()});
});

// Gère une connexion via mot de passe.
router.post('/pwd-login', pwdLogin)

// Gère une connexion validée avec FC
router.get('/callback', oauthCallback);

// Valide un compte utilisateur avec les infomations complémentaires
router.post('/verify', async (req,res) => {
    log.i('::verify - In')
    if(!req.body.id){
        log.w('::verify - Aucun ID à ajouter en base.') 
        return res.sendStatus(500)
    }
    var wasValidated = req.body.validated
    const tokenFc = req.body.tokenFc
    var user = formatUtilisateur(req.body, false)

   
    // Vérifier si l'email est déjà utilisé en base.
    const mailExistenceQuery = await pgPool.query(`SELECT uti_mail,uti_pwd, uti_tockenfranceconnect FROM utilisateur WHERE uti_mail='${user.uti_mail}'`).catch(err => {
        log.w(err)
        throw err
    })

    if(mailExistenceQuery && mailExistenceQuery.rowCount > 0 && mailExistenceQuery.rows[0].uti_pwd && tokenFc) {
        log.w('Vérifications complémentaires nécessaires avant ajout en base. ')
        return res.status(200).json({ existingUser: formatUtilisateur(mailExistenceQuery.rows[0]) })
    } 

    // Pour un maitre nageur, vérifier si le numéro EAPS est présent dans la table ref_eaps
    console.log(user)
    console.log(user.uti_eaps)
    console.log(user.uti_mailcontact)
    if (user.eaps != '') {
        log.d('::verify - Recherche numéro EAPS') 
        const eapslExistenceQuery = await pgPool.query(`SELECT eap_numero FROM ref_eaps WHERE eap_numero='${user.uti_eaps}'`).catch(err => {
            log.w(err)
            throw err

        })
        if (eapslExistenceQuery.rowCount == 0) {
            return res.status(200).json({nonAuthorizedUser: 'Vous n\'êtes pas autorisés à vous créer un compte'})
        }
    }

    log.d('::verify - Mise à jour de l\'utilisateur existant')   
/*
    console.log(user.uti_mailcontact)
    console.log(user.uti_compadrcontact)
    console.log('cp' + user.uti_com_cp_contact)
    console.log('commune : ' +user.uti_com_libellecontact.com_libellemaj)
    console.log('insee : ' +user.uti_com_libellecontact.cpi_codeinsee)
    */
    log.i('::verify : user.mailcontact' + user.uti_mailcontact)
    const bddRes = await pgPool.query("UPDATE utilisateur SET  uti_mail = $1, uti_nom = $2, uti_prenom = $3, uti_validated = true, \
    uti_eaps = $4, uti_publicontact = $5, uti_mailcontact = $7, uti_sitewebcontact = $8, uti_adrcontact = $9, uti_compadrcontact = $10, uti_telephonecontact = $11, uti_com_libellecontact = $12, uti_com_codeinseecontact = $13, uti_com_cp_contact = $14 WHERE uti_id = $6 RETURNING *", 
    [user.uti_mail, user.uti_nom, user.uti_prenom, user.uti_eaps,Boolean(user.uti_publicontact), user.uti_id, user.uti_mailcontact,user.uti_sitewebcontact,user.uti_adrcontact, user.uti_compadrcontact,user.uti_telephonecontact, user.uti_com_libellecontact.com_libellemaj , user.uti_com_libellecontact.cpi_codeinsee, user.uti_com_cp_contact]).catch(err => {
        console.log(err)
        throw err
    })
    
    // Envoie de l'email de confirmation
    if(!wasValidated){
        log.d('::verify - Mail de confirmation envoyé.')
        sendEmail({
            to: user.uti_mail,
            subject: 'création compte savoir rouler à vélo',
            body: `<p>Bonjour,</p>
                <p>Votre compte « Aisance Aquatique » a bien été créé. <br/><br/>
                Nous vous invitons à y renseigner les informations relatives à la mise en œuvre de chacun des 3 blocs du socle commun du SRAV.<br/>
                Le site <a href="www.savoirrouleravelo.fr">www.savoirrouleravelo.fr</a> est à votre disposition pour toute information sur le programme Savoir Rouler à Vélo.<br/></p>`
        })
    }

    req.session.user = bddRes.rows[0]
    user = formatUtilisateur(bddRes.rows[0])
    log.i('::verify - Done')
    return res.send({user})
})

// Nouveur user FC mais qui a déjà une connexion via mot de passe.
// Vérification des duplicatas en base sur base de tokenFC et update du user existant
router.put('/confirm-profil-infos', async (req,res) => {
    const user = req.body && req.body.user
    const mail = user && user.mail
    const tokenFc = user && user.tokenFc
    const candidate = user && user.password && await crypto.createHash('md5').update(user.password).digest('hex')
    log.i('::confirm-profil-infos - In', {mail , candidate, tokenFc})

    const authConfirmationQuery = await pgPool.query(`SELECT * FROM utilisateur WHERE uti_mail='${mail}'`).catch(err => {
        log.w('::confirm-profil-infos - Erreur pendant la suppression des users.', err)
        throw err
    })

    const existingUser = authConfirmationQuery.rows && authConfirmationQuery.rows[0]
    const isMatch = existingUser.uti_pwd && existingUser.uti_pwd === candidate
    if(!isMatch) {
        log.w('::confirm-profil-infos - Les mots de passes ne matchent pas.')
        return res.status(400).json({message: 'Le mot de passe fourni est incorrect ou l\'utilisateur n\'en possède pas. Veuillez contacter l\'assistance.'});        
    }

    await pgPool.query(`DELETE FROM utilisateur WHERE uti_tockenfranceconnect='${tokenFc}' RETURNING *`).catch(err => {
        log.w('::confirm-profil-infos - Erreur pendant la suppression des users.', err)
        throw err
    })
    
    const bddUpdate =  await pgPool.query("UPDATE utilisateur SET uti_tockenfranceconnect = $1, uti_mail = $2, uti_prenom = $3, uti_nom = $4 \
    WHERE uti_id = $5 RETURNING *", 
    [tokenFc, mail, user.prenom, user.nom, existingUser.uti_id]).catch(err => {
        log.w('::confirm-profil-infos - Erreur pendant l\'update des infos du user', err)
        throw err
    })
    
    const updatedUser = bddUpdate.rows && bddUpdate.rows[0]
    log.d('::confirm-profil-infos - Done, renvois du user mis à jour', updatedUser)
    req.session.user = updatedUser
    req.accessToken = updatedUser.uti_tockenfranceconnect;
    req.session.accessToken = updatedUser.uti_tockenfranceconnect;
    return res.send(formatUtilisateur(updatedUser))
})

router.post('/create-account-pwd', async (req, res) => {
    log.i('::create-account-pwd - In')
    const { password , mail, confirm } = req.body
    if(!password || !mail || !confirm) {
        throw new Error("Un paramètre manque pour effectuer l'inscription.")
    }
    const formatedMail = mail.toLowerCase()
    const crypted = await crypto.createHash('md5').update(password).digest('hex')
    let bddRes
    let confirmInscription
    // Vérifier si l'email est déjà utilisé en base.
    const mailExistenceQuery = await pgPool.query(`SELECT uti_id, uti_mail, uti_tockenfranceconnect FROM utilisateur WHERE uti_mail='${formatedMail}'`).catch(err => {
        log.w(err)
        throw err
    })

    if(mailExistenceQuery && mailExistenceQuery.rowCount > 0) {
        if(mailExistenceQuery.rows[0].uti_tockenfranceconnect && !mailExistenceQuery.rows[0].pwd) {
            log.d('::create-account-pwd - Utilisateur déjà connecté via FC.')
        // ENVOI MAIL ???????
        //
        //
        //
            confirmInscription = false
            bddRes = await pgPool.query(`UPDATE utilisateur SET uti_pwd= $1 WHERE uti_id= $2 RETURNING *`, [ crypted, mailExistenceQuery.rows[0].uti_id]
                ).catch(err => {
                    console.log(err)
                    throw err
                })
        } else {
            return res.status(400).json({message: 'Veuillez contacter l\'assistance.'});        
        }
    } else {
        log.d('::create-account-pwd - Nouveau user, authentifié via password, à ajouter en base')
        confirmInscription = true    
        bddRes = await pgPool.query(
            'INSERT INTO utilisateur(rol_id, stu_id, uti_mail, uti_validated, uti_pwd)\
            VALUES($1, $2, $3, $4, $5) RETURNING *'
            , [3, 1, formatedMail, false, crypted ]
          ).catch(err => {
            console.log(err)
            throw err
          })
    }

    req.session.user = bddRes.rows[0]
    req.accessToken = bddRes.rows[0].uti_pwd;
    req.session.accessToken = bddRes.rows[0].uti_pwd;
    const user = formatUtilisateur(bddRes.rows[0])
    log.i('::create-account-pwd - Done')
    return res.send({ user, confirmInscription })
})

// Envoie l'utilisateur de la session
router.get('/user', (req,res) => {
    if(!req.session || !req.session.user || !req.session.accessToken){
        return res.sendStatus(404)
    }
    return res.send(formatUtilisateur(req.session.user))
})

router.put('/edit-mon-compte/:id', async function (req, res) {
    const profil = req.body.profil
    const id = req.params.id
    log.i('::edit-mon-compte - In', { id })
    if(!id) {
        return res.status(400).json('Aucun ID fournit pour  identifier l\'utilisateur.');
    }
    //insert dans la table intervention
    const requete = `UPDATE utilisateur 
        SET uti_mail = $1,
        uti_structurelocale = $2
        WHERE uti_id = ${id}
        RETURNING *
        ;`    
    pgPool.query(requete,[profil.mail, profil.structureLocale], (err, result) => {
        if (err) {
            log.w('::edit-mon-compte - erreur lors de l\'update', {requete, erreur: err.stack});
            return res.status(400).json('erreur lors de la sauvegarde de l\'utilisateur');
        }
        else {
            log.i('::edit-mon-compte - Done')
            req.session.user = result.rows[0]
            return res.status(200).json({ user: formatUtilisateur(result.rows[0])});
        }
    })
})


// Envoie l'url FC pour se déconnecter
router.get('/logout', async(req, res) => {
    log.i('::logout - In')
    let url
    if(req.session.idToken) url = await getLogoutUrl(req)
    req.session && req.session.destroy()
    res.send({url});
});

// Nettoie la session de l'utilisateur
router.get('/logged-out', (req, res) => {
    log.i('::logged-out - In')    
    // Resetting the id token hint.
    req.session.idToken = null;
    // Resetting the userInfo.
    req.session.user = null;
    return res.send('OK')
});

router.get('/', function (req, res) {
    res.send('Ceci est la route de connexion');
});

module.exports = router;