#!/usr/bin/env brew ruby
directories = ["_data/formula", "api/formula", "formula", "_data/cask", "api/cask", "cask"]
FileUtils.rm_rf directories
FileUtils.mkdir_p directories

formulae_indexes = []
Formula.each do |f|
  json_filename = "#{f.name}.json"
  IO.write("_data/formula/#{json_filename}", JSON.pretty_generate(f.to_hash))
  FileUtils.cp "_api_formula.json.in", "api/formula/#{json_filename}"

  html = IO.read "_formula.html.in"
  html.gsub!("title: $TITLE", "title: #{f.name}")
  IO.write("formula/#{f.name}.html", html)
  formulae_indexes << {
	name: f.name,
	full_name: f.full_name,
	aliases: f.aliases,
	description: f.desc,
	homepage: f.homepage,
	versions: f.version,
	revision: f.revision,
	keg_only: f.keg_only?,
	bottle: f.pour_bottle?,
	versioned: f.versioned_formula?
  }
end

require 'cask/cask'
Cask::Cask.each do |c|
  json_filename = "#{File.basename(c.sourcefile_path,'.rb')}.json"
  IO.write("_data/cask/#{json_filename}", JSON.pretty_generate(c.to_h))
  FileUtils.cp "_api_formula.json.in", "api/cask/#{json_filename}"
end

require 'algoliasearch'
Algolia.init(application_id: ARGV[0],
             api_key:        ARGV[1])
index = Algolia::Index.new('formula')
index.clear_index()
index.add_objects(formulae_indexes)