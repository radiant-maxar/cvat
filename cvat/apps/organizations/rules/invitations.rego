package invitations

import rego.v1

import data.utils
import data.organizations

# input: {
#     "scope": <"list"|"create"|"view"|"resend"|"accept"|"delete"> or null,
#     "auth": {
#         "user": {
#             "id": <num>,
#             "privilege": <"admin"|"user"|"worker"> or null
#         },
#         "organization": {
#             "id": <num>,
#             "owner": {
#                 "id": <num>
#             },
#             "user": {
#                 "role": <"owner"|"maintainer"|"supervisor"|"worker"> or null
#             }
#         } or null,
#     },
#     "resource": {
#         "owner": { "id": <num> },
#         "invitee": { "id": <num> },
#         "role": <"owner"|"maintainer"|"supervisor"|"worker">,
#         "organization": { "id": <num> }
#     } or null,
# }

default allow := false

allow if {
    utils.is_admin
}

allow if {
    input.scope == utils.LIST
    utils.is_sandbox
}

allow if {
    input.scope == utils.LIST
    organizations.is_member
}

filter := [] if { # Django Q object to filter list of entries
    utils.is_sandbox
    utils.is_admin
} else := qobject if {
    utils.is_sandbox
    user := input.auth.user
    qobject := [ {"owner": user.id}, {"membership__user": user.id}, "|" ]
} else := qobject if {
    utils.is_organization
    utils.is_admin
    qobject := [ {"membership__organization": input.auth.organization.id} ]
} else := qobject if {
    utils.is_organization
    organizations.is_staff
    utils.has_perm(utils.USER)
    qobject := [ {"membership__organization": input.auth.organization.id} ]
} else := qobject if {
    utils.is_organization
    user := input.auth.user
    org_id := input.auth.organization.id
    qobject := [ {"owner": user.id}, {"membership__user": user.id}, "|",
        {"membership__organization": org_id}, "&" ]
}

allow if {
    input.scope == utils.CREATE
    input.auth.organization.id == input.resource.organization.id
    utils.has_perm(utils.USER)
    input.auth.organization.user.role == organizations.MAINTAINER
    # a maintainer cannot invite an user with owner or  maintainer roles
    input.resource.role != organizations.OWNER
    input.resource.role != organizations.MAINTAINER

}

allow if {
    input.scope == utils.CREATE
    input.auth.organization.id == input.resource.organization.id
    utils.has_perm(utils.USER)
    organizations.is_owner
    # it isn't possible to create one more owner at the moment
    input.resource.role != organizations.OWNER
}

allow if {
    input.scope == utils.VIEW
    utils.is_sandbox
    utils.is_resource_owner
}

allow if {
    input.scope == utils.VIEW
    utils.is_sandbox
    input.resource.invitee.id == input.auth.user.id
}

allow if {
    input.scope == utils.VIEW
    input.auth.organization.id == input.resource.organization.id
    utils.has_perm(utils.USER)
    organizations.is_staff
}

allow if {
    input.scope == utils.VIEW
    input.auth.organization.id == input.resource.organization.id
    utils.is_resource_owner
}

allow if {
    input.scope == utils.VIEW
    input.auth.organization.id == input.resource.organization.id
    input.resource.invitee.id == input.auth.user.id
}

allow if {
    input.scope == utils.RESEND
    utils.has_perm(utils.WORKER)
    utils.is_sandbox
    utils.is_resource_owner
}

allow if {
    input.scope == utils.RESEND
    input.auth.organization.id == input.resource.organization.id
    utils.has_perm(utils.USER)
    organizations.is_staff
}

allow if {
    input.scope == utils.RESEND
    input.auth.organization.id == input.resource.organization.id
    utils.has_perm(utils.WORKER)
    utils.is_resource_owner
}

allow if {
    input.scope == utils.DELETE
    utils.is_sandbox
    utils.has_perm(utils.WORKER)
    utils.is_resource_owner
}

allow if {
    input.scope == utils.DELETE
    input.auth.organization.id == input.resource.organization.id
    utils.has_perm(utils.USER)
    organizations.is_staff
}

allow if {
    input.scope == utils.DELETE
    input.auth.organization.id == input.resource.organization.id
    utils.has_perm(utils.WORKER)
    utils.is_resource_owner
}


allow if {
    input.scope in {utils.ACCEPT, utils.DECLINE}
    input.resource.invitee.id == input.auth.user.id
    utils.is_sandbox
}

allow if {
    input.scope in {utils.ACCEPT, utils.DECLINE}
    input.auth.organization.id == input.resource.organization.id
    input.resource.invitee.id == input.auth.user.id
}
