# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131104141642) do

  create_table "hits", :force => true do |t|
    t.integer "host_id",                     :null => false
    t.string  "path",        :limit => 1024, :null => false
    t.string  "path_hash",   :limit => 40,   :null => false
    t.string  "http_status", :limit => 3,    :null => false
    t.integer "count",                       :null => false
    t.date    "hit_on",                      :null => false
  end

  add_index "hits", ["host_id", "hit_on"], :name => "index_hits_on_host_id_and_hit_on"
  add_index "hits", ["host_id", "http_status"], :name => "index_hits_on_host_id_and_http_status"
  add_index "hits", ["host_id", "path_hash", "hit_on", "http_status"], :name => "index_hits_on_host_id_and_path_hash_and_hit_on_and_http_status", :unique => true
  add_index "hits", ["host_id"], :name => "index_hits_on_host_id"

  create_table "hits_staging", :id => false, :force => true do |t|
    t.string  "hostname"
    t.string  "path",        :limit => 1024
    t.string  "http_status", :limit => 3
    t.integer "count"
    t.date    "hit_on"
  end

  create_table "hosts", :force => true do |t|
    t.integer  "site_id"
    t.string   "hostname"
    t.integer  "ttl"
    t.string   "cname"
    t.string   "live_cname"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "hosts", ["hostname"], :name => "index_hosts_on_host", :unique => true
  add_index "hosts", ["site_id"], :name => "index_hosts_on_site_id"

  create_table "mappings", :force => true do |t|
    t.integer "site_id",                       :null => false
    t.string  "path",          :limit => 1024, :null => false
    t.string  "path_hash",     :limit => 40,   :null => false
    t.string  "http_status",   :limit => 3,    :null => false
    t.text    "new_url"
    t.text    "suggested_url"
    t.text    "archive_url"
  end

  add_index "mappings", ["site_id", "http_status"], :name => "index_mappings_on_site_id_and_http_status"
  add_index "mappings", ["site_id", "path_hash"], :name => "index_mappings_on_site_id_and_path_hash", :unique => true
  add_index "mappings", ["site_id"], :name => "index_mappings_on_site_id"

  create_table "mappings_staging", :id => false, :force => true do |t|
    t.text   "old_url"
    t.text   "new_url"
    t.string "http_status"
    t.string "host"
    t.string "path"
    t.string "path_hash"
    t.text   "suggested_url"
    t.text   "archive_url"
  end

  create_table "organisations", :force => true do |t|
    t.string   "abbr"
    t.string   "title"
    t.date     "launch_date"
    t.string   "homepage"
    t.string   "furl"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "css"
    t.string   "ga_profile_id",  :limit => 16
    t.integer  "parent_id"
    t.string   "whitehall_slug"
    t.string   "whitehall_type"
  end

  add_index "organisations", ["abbr"], :name => "index_organisations_on_abbr", :unique => true
  add_index "organisations", ["title"], :name => "index_organisations_on_title"

  create_table "sites", :force => true do |t|
    t.integer  "organisation_id"
    t.string   "abbr"
    t.string   "query_params"
    t.datetime "tna_timestamp"
    t.string   "homepage"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "global_http_status", :limit => 3
    t.text     "global_new_url"
  end

  add_index "sites", ["abbr"], :name => "index_sites_on_site", :unique => true
  add_index "sites", ["organisation_id"], :name => "index_sites_on_organisation_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "uid"
    t.text     "permissions"
    t.boolean  "remotely_signed_out", :default => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "organisation"
  end

  create_table "versions", :force => true do |t|
    t.string   "item_type",      :null => false
    t.integer  "item_id",        :null => false
    t.string   "event",          :null => false
    t.string   "whodunnit"
    t.integer  "user_id"
    t.text     "object_changes"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end