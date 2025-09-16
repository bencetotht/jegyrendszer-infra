# https://www.youtube.com/watch?v=mGOTpRfulfQ

# user invitation write stage
resource "authentik_stage_user_write" "enrollment-invitation-write" {
  name                     = "enrollment-invitation-write"
  create_users_as_inactive = false
}

# invitation stage
resource "authentik_stage_invitation" "enrollment-invitation" {
  name = "enrollment-invitation"
  continue_flow_without_invitation = false
}

resource "authentik_flow" "enrollment-invitation-flow" {
  name        = "Enrollment Invitation"
  title       = "Enrollment Invitation"
  slug        = "enrollment-invitation"
  designation = "enrollment"
  authentication = "none"

  compatibility_mode = true
}

resource "authentik_flow_stage_binding" "enrollment-invitation-flow-invitation" {
  target = authentik_flow.enrollment-invitation-flow.uuid
  stage  = authentik_stage_invitation.enrollment-invitation.id
  order  = 10
}

data "authentik_stage_prompt" "default-source-enrollment-prompt" {
  name = "default-source-enrollment-prompt"
}

resource "authentik_flow_stage_binding" "enrollment-invitation-flow-prompt" {
  target = authentik_flow.enrollment-invitation-flow.uuid
  stage  = data.authentik_stage_prompt.default-source-enrollment-prompt.id
  order  = 20
}

resource "authentik_flow_stage_binding" "enrollment-invitation-flow-write" {
  target = authentik_flow.enrollment-invitation-flow.uuid
  stage  = authentik_stage_user_write.enrollment-invitation-write.id
  order  = 30
}

data "authentik_stage_user_login" "default-source-enrollment-login" {
  name = "default-source-enrollment-login"
}

resource "authentik_flow_stage_binding" "enrollment-invitation-flow-login" {
  target = authentik_flow.enrollment-invitation-flow.uuid
  stage  = data.authentik_stage_user_login.default-source-enrollment-login.id
  order  = 40
}