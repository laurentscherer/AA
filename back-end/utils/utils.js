/**
 * Format the url use in the redirection call
 * to the France Connect Authorization and logout API endpoint.
 * @see @link{ https://partenaires.franceconnect.gouv.fr/fcp/fournisseur-service# }
 */

var config = require('../config')
var moment = require('moment');


module.exports = {

  // TODO hard code state et nonce because they normally generate from every request
  getAuthorizationUrl : () => `${config.franceConnect.FC_URL}${config.franceConnect.AUTHORIZATION_FC_PATH}?`
    + `response_type=code&client_id=${config.franceConnect.CLIENT_ID}&redirect_uri=${config.franceConnect.FS_URL}`
    + `${config.franceConnect.CALLBACK_FS_PATH}&scope=${config.franceConnect.SCOPES}&state=customState11&nonce=customNonce11`
  
  
  /**
   * Format the url 's that is used in a redirect call to France Connect logout API endpoint
   * @returns {string}
   */
   , getLogoutUrl : req => `${config.franceConnect.FC_URL}${config.franceConnect.LOGOUT_FC_PATH}?id_token_hint=`
    + `${req.session.idToken}&state=customState11&post_logout_redirect_uri=${config.franceConnect.FS_URL}`
    + `${config.franceConnect.LOGOUT_FS_PATH}`

  , formatUtilisateur : (utilisateur, toClient = true) => {
    if(toClient){
      return {
            id: utilisateur.uti_id,
            authId: utilisateur.uti_authid,
            profilId: utilisateur.rol_id,
            statutId: utilisateur.stu_id,
            mail: utilisateur.uti_mail,
            nom: utilisateur.uti_nom,
            prenom: utilisateur.uti_prenom,
            tokenFc: utilisateur.uti_tockenfranceconnect,
            validated: utilisateur.uti_validated,
            eaps: utilisateur.uti_eaps,
            publicontact: utilisateur.uti_publicontact,
            mailcontact: utilisateur.uti_mailcontact,            
            sitewebcontact: utilisateur.uti_sitewebcontact,
            adrcontact: utilisateur.uti_adrcontact,
            compadrcontact: utilisateur.uti_compadrcontact,

              cpi_codeinsee: utilisateur.uti_com_codeinseecontact,
            cp: utilisateur.uti_com_cp_contact,
            telephonecontact: utilisateur.uti_telephonecontact
      }
    } else { 
      return {
            uti_id : utilisateur.id ,
            uti_authid: utilisateur.uti_authid ,
            rol_id : utilisateur.profilId ,
            stu_id : utilisateur.statutId ,
            uti_mail : utilisateur.mail && utilisateur.mail.toLowerCase() ,
            uti_nom : utilisateur.nom ,
            uti_prenom : utilisateur.prenom ,
            uti_structurelocale : utilisateur.structureLocale ,
            uti_tockenfranceconnect : utilisateur.tokenFc ,
            uti_validated: utilisateur.validated,
            uti_eaps: utilisateur.eaps,
            uti_publicontact: utilisateur.publicontact,
            uti_mailcontact: utilisateur.mailcontact,
            uti_sitewebcontact: utilisateur.sitewebcontact,
            uti_adrcontact : utilisateur.adrcontact,
            uti_compadrcontact : utilisateur.compadrcontact,
            uti_com_cp_contact: utilisateur.cp,
            uti_com_codeinseecontact: utilisateur.cpi_codeinsee,
            uti_telephonecontact: utilisateur.telephonecontact
        }
    }
}
}
