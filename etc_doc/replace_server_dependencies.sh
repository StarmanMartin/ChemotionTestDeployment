#!/usr/bin/env bash
set -euo pipefail

cd /chemotion/chem

DEPENDENCY_FILE="/chemotion/server_dependencies.json"
GEMFILE="/chemotion/chem/Gemfile"

if [ ! -f "$DEPENDENCY_FILE" ]; then
    echo "Missing $DEPENDENCY_FILE"
    exit 1
fi

if [ ! -f "$GEMFILE" ]; then
    echo "Missing $GEMFILE"
    exit 1
fi

DEPENDENCY_FILE="$DEPENDENCY_FILE" GEMFILE="$GEMFILE" ruby <<'RUBY'
require "json"

replacements = JSON.parse(File.read(ENV.fetch("DEPENDENCY_FILE")))

gemfile = File.read(ENV.fetch("GEMFILE"))

replacements.each do |name, spec|
  # Remove existing declaration
  gemfile.gsub!(
    /^\s*gem\s+["']#{Regexp.escape(name)}["'].*$/,
    ""
  )

  declaration =
    case spec
    when String
      %(gem "#{name}", "#{spec}")
    when Hash
      if spec["git"]
        branch = spec["branch"] ? %(, branch: "#{spec["branch"]}") : ""
        %(gem "#{name}", git: "#{spec["git"]}"#{branch})
      elsif spec["path"]
        %(gem "#{name}", path: "#{spec["path"]}")
      elsif spec["version"]
        %(gem "#{name}", "#{spec["version"]}")
      else
        raise "Unsupported dependency format for #{name}"
      end
    else
      raise "Invalid dependency format for #{name}"
    end

  gemfile << "\n#{declaration}\n"
end

File.write(ENV.fetch("GEMFILE"), gemfile)
RUBY

echo "Gemfile dependencies replaced."

cd /chemotion