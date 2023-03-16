# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_03_16_024216) do
  create_table "clinicians", force: :cascade do |t|
    t.integer "npi"
    t.integer "ind_PAC_ID"
    t.string "last_name"
    t.string "first_name"
    t.string "middle_name"
    t.string "suffix"
    t.string "credential"
    t.string "medical_school"
    t.integer "graduation_year"
    t.string "primary_speciality"
    t.string "secondary_speciality_1"
    t.string "secondary_speciality_2"
    t.string "secondary_speciality_3"
    t.string "secondary_speciality_4"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "organization_id"
  end

  create_table "clinicians_facilities", id: false, force: :cascade do |t|
    t.integer "clinician_id", null: false
    t.integer "facility_id", null: false
  end

  create_table "codes", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.string "plain_language_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "benchmark_cost"
  end

  create_table "facilities", force: :cascade do |t|
    t.string "name"
    t.string "address_line_one"
    t.string "address_line_two"
    t.string "address_city"
    t.string "address_state"
    t.string "address_zip_code"
    t.integer "npi"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "org_PAC_ID"
    t.string "facility_id"
    t.string "facility_type"
    t.string "overall_rating"
    t.float "latitude"
    t.float "longitude"
  end

  create_table "health_plan_networks", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "negotiated_rates", force: :cascade do |t|
    t.string "billing_code"
    t.string "billing_code_type"
    t.string "negotiation_arrangement"
    t.string "negotiated_type"
    t.decimal "negotiated_rate"
    t.date "experation_date"
    t.string "billing_class"
    t.text "service_code", default: "--- []\n"
    t.text "billing_code_modifier", default: "--- []\n"
    t.integer "tin"
    t.string "tin_type"
    t.integer "npi"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "facility_id"
    t.integer "clinician_id"
    t.integer "code_id"
    t.integer "health_plan_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.integer "org_PAC_ID"
    t.integer "num_org_members"
    t.string "address_line_one"
    t.string "address_line_two"
    t.string "address_city"
    t.string "address_state"
    t.string "address_zip"
    t.integer "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ratings", force: :cascade do |t|
    t.string "measure_cd"
    t.string "measure_title"
    t.integer "star_value"
    t.integer "facility_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "organization_id"
  end

  create_table "services", force: :cascade do |t|
    t.decimal "gross_charge"
    t.decimal "self_pay_cash_price"
    t.decimal "aetna_commercial"
    t.decimal "aetna_asa"
    t.decimal "cbc_commercial"
    t.decimal "cigna"
    t.decimal "geisinger_commercial"
    t.decimal "highmark_choice_blue"
    t.decimal "highmark_commercial"
    t.decimal "multiplan"
    t.decimal "uhc_commercial"
    t.decimal "upmc_commercial"
    t.decimal "wellspan"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "facility_id"
    t.integer "code_id"
    t.index ["code_id"], name: "index_services_on_code_id"
    t.index ["facility_id"], name: "index_services_on_facility_id"
  end

  create_table "timely_and_effective_care_ratings", force: :cascade do |t|
    t.string "condition"
    t.string "measure_id"
    t.string "measure_name"
    t.string "score"
    t.string "sample"
    t.integer "facility_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "utilizations", force: :cascade do |t|
    t.string "hcpcs_code"
    t.string "hcpcs_description"
    t.integer "service_count"
    t.integer "beneficiary_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "clinician_id"
  end

end
