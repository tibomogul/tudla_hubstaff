import { application } from "tudla_hubstaff/application"

import UserMappingModalController from "tudla_hubstaff/controllers/user_mapping_modal_controller"
import TaskMappingModalController from "tudla_hubstaff/controllers/task_mapping_modal_controller"
import ProjectMappingModalController from "tudla_hubstaff/controllers/project_mapping_modal_controller"

application.register("user-mapping-modal", UserMappingModalController)
application.register("task-mapping-modal", TaskMappingModalController)
application.register("project-mapping-modal", ProjectMappingModalController)

console.log("TudlaHubstaff controllers registered")
