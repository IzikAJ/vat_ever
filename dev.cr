require "sentry"

sentry = Sentry::ProcessRunner.new(
  display_name: "VatEver DEV",
  build_command: "crystal build ./src/vat_ever.cr -o ./bin/vat_ever",
  run_command: "./bin/vat_ever",
  files: ["./src/**/*.cr", "./src/**/*.ecr"]
)

sentry.run
