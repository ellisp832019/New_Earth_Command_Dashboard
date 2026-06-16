# Local-first Policy

The Dashboard should keep sensitive project, family, finance, grant, and AI workflow data local wherever possible.

## Data categories

- Public: website content, public posts, published documentation
- Internal: project plans, module docs, repo structure
- Private: finance, grants, family, legal, personal records
- Restricted: credentials, API keys, identity data, passwords

## Rules

- Do not place secrets in docs.
- Do not commit `.env` files.
- Do not send private records to external AI tools without explicit approval.
- Prefer local models for sensitive knowledge processing.
