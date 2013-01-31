login: &login
  adapter: postgresql
  host: localhost
  username: postgres

development:
  database: typo_dev
  <<: *login

staging:
  database: typo_tests
  <<: *login

production:
  database: typo
  <<: *login
