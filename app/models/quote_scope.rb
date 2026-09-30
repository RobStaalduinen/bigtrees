# == Schema Information
#
# Table name: quote_scopes
#
#  id            :integer          not null, primary key
#  estimate_id   :integer          not null
#  scope_of_work :text
#  inclusions    :json
#  exclusions    :json
#
# Scope of work, inclusions and exclusions for the quote PDF. All three are
# optional — a quote with none of them set simply renders without those
# sections. Column is `scope_of_work` rather than `scope` to stay clear of
# ActiveRecord's own `scope`.
class QuoteScope < ActiveRecord::Base
  belongs_to :estimate

  before_save :normalise_lists

  # JSON columns come back nil until first written, and the editor can submit
  # blank rows when someone adds a bullet and doesn't fill it in.
  def inclusions
    clean(self[:inclusions])
  end

  def exclusions
    clean(self[:exclusions])
  end

  # Whether this record has anything worth rendering on the quote.
  def any?
    scope_of_work.present? || inclusions.any? || exclusions.any?
  end

  private

    def normalise_lists
      self[:inclusions] = clean(self[:inclusions])
      self[:exclusions] = clean(self[:exclusions])
      self.scope_of_work = scope_of_work.presence&.strip
    end

    def clean(value)
      Array(value).map { |v| v.to_s.strip }.reject(&:blank?)
    end
end
