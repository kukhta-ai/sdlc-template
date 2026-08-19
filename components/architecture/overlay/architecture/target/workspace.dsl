# For a brownfield redesign, extend ../baseline/workspace.dsl after modeling the as-is system there.
workspace extends ../base/workspace.dsl {
    name "__PROJECT_NAME_DSL__ - target architecture"
    model {
        archetypes {
            !include archetypes.dsl
        }

        !include model.dsl
        !include deployment.dsl
    }

    views {
        !include views.dsl
    }
}
