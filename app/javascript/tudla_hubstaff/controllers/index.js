// TudlaHubstaff Stimulus Controllers
// Registers engine controllers with the host application's Stimulus instance.
// We import from the host's "application" module to ensure Stimulus is initialized first.

import { application } from "application"

import UserMappingModalController from "tudla_hubstaff/controllers/user_mapping_modal_controller"
import TaskMappingModalController from "tudla_hubstaff/controllers/task_mapping_modal_controller"
import ProjectMappingModalController from "tudla_hubstaff/controllers/project_mapping_modal_controller"
import ActivityTaskMappingModalController from "tudla_hubstaff/controllers/activity_task_mapping_modal_controller"

application.register("user-mapping-modal", UserMappingModalController)
application.register("task-mapping-modal", TaskMappingModalController)
application.register("project-mapping-modal", ProjectMappingModalController)
application.register("activity-task-mapping-modal", ActivityTaskMappingModalController)
