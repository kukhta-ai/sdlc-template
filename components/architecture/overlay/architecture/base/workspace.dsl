workspace "__PROJECT_NAME_DSL__ architecture base" {
    !identifiers hierarchical
    !impliedRelationships com.structurizr.model.CreateImpliedRelationshipsUnlessSameRelationshipExistsStrategy

    model {
        # Enable nested groups support
        properties {
            "structurizr.groupSeparator" "/"
        }
        archetypes {
            !include archetypes.dsl
        }

        !include model.dsl
    }

    views {
        styles {
            !include styles.dsl
        }
    }
}
