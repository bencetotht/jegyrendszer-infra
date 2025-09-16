# proxmox

# grafana
data "authentik_flow" "default-provider-authorization-implicit-consent" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_property_mapping_provider_scope" "scope-email" {
  name = "authentik default OAuth Mapping: OpenID 'email'"
}

data "authentik_property_mapping_provider_scope" "scope-profile" {
  name = "authentik default OAuth Mapping: OpenID 'profile'"
}

data "authentik_property_mapping_provider_scope" "scope-openid" {
  name = "authentik default OAuth Mapping: OpenID 'openid'"
}

resource "authentik_provider_oauth2" "grafana" {
  name          = "Grafana"
  # use: openssl rand -hex 16
  client_id     = "my_client_id"

  authorization_flow  = data.authentik_flow.default-provider-authorization-implicit-consent.id

  redirect_uris = ["https://grafana.bnbdevelopment.hu/login/generic_oauth"]

  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
  ]
}

resource "authentik_application" "grafana" {
  name              = "Grafana"
  slug              = "grafana"
  protocol_provider = authentik_provider_oauth2.grafana.id
}

# webstats proxy provider
resource "authentik_provider_proxy" "webstats" {
  name               = "Webstats"
  external_host      = "http://webstats.bnbdevelopment.hu"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
}

resource "authentik_application" "webstats" {
  name              = "Webstats"
  slug              = "webstats"
  protocol_provider = authentik_provider_proxy.webstats.id
}