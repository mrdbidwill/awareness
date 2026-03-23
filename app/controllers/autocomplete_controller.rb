# frozen_string_literal: true

class AutocompleteController < ApplicationController
  skip_after_action :verify_authorized, raise: false
  skip_after_action :verify_policy_scoped, raise: false

  # GET /autocomplete/genera.json?q=Gano
  # Returns only true genus-level entries (rank_name = 'gen.' or 'Genus').
  def genera
    q = params[:q].to_s.strip
    return render json: [] if q.length < 3

    scope = MbList.where("taxon_name LIKE ?", "#{sanitize_like(q)}%")
                  .where(rank_name: %w[gen. Genus])
    scope = scope.where(name_status: "Legitimate") if MbList.column_names.include?("name_status")

    items = scope.select(:id, :taxon_name)
                 .order(:taxon_name)
                 .limit(20)
                 .map { |row| { id: row.id, name: row.taxon_name } }

    render json: items
  end

  # GET /autocomplete/species.json?q=sessi&genus_name=Ganoderma
  # Uses strict species rank, and when genus_name is present, requires binomial
  # prefix match: "Genus epithet...".
  def species
    q = params[:q].to_s.strip
    genus_name = params[:genus_name].to_s.strip
    return render json: [] if q.length < 3

    scope = MbList.where(rank_name: %w[sp. Species])
    scope = scope.where(name_status: "Legitimate") if MbList.column_names.include?("name_status")

    if genus_name.present?
      scope = scope.where("taxon_name LIKE ?", "#{sanitize_like(genus_name)} #{sanitize_like(q)}%")
    else
      scope = scope.where("taxon_name LIKE ?", "#{sanitize_like(q)}%")
    end

    items = scope.select(:id, :taxon_name)
                 .order(:taxon_name)
                 .limit(20)
                 .map { |row| { id: row.id, name: row.taxon_name } }

    render json: items
  end

  private

  def sanitize_like(term)
    term.gsub(/[\\%_]/) { |m| "\\#{m}" }
  end
end
