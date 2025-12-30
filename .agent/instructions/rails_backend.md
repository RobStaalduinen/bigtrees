# Rails Backend Development Rules

- **RESTful Architecture**: Prefer strict following of RESTful format unless instructed otherwise.
- **Custom Actions**: Create new resources (controllers/routes) for custom actions where applicable, rather than adding non-standard actions to existing controllers.
- **Service Objects**: Create service objects to encapsulate business logic. Avoid expanding controllers with complex logic.
