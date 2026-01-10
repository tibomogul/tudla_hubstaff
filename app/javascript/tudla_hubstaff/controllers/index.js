import { application } from "tudla_hubstaff/application"

import UserMappingModalController from "tudla_hubstaff/controllers/user_mapping_modal_controller"
application.register("user-mapping-modal", UserMappingModalController)

console.log("TudlaHubstaff controllers registered")
