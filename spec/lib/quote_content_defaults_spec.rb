require 'rails_helper'

RSpec.describe QuoteContentDefaults do
  include ActionView::Helpers::SanitizeHelper

  def clean(html)
    sanitize(html, tags: described_class::ALLOWED_TAGS, attributes: [])
  end

  describe 'the stock copy' do
    # Compared by tag set, not byte equality: sanitize decodes entities, so
    # `&mdash;` legitimately comes back as a literal em dash.
    it 'uses only tags the PDF keeps — the defaults must not rely on anything stripped' do
      [described_class::TERMS, described_class::PRE_JOB].each do |html|
        tags_in  = html.scan(/<(\w+)[^>]*>/).flatten.uniq.sort
        tags_out = clean(html).scan(/<(\w+)[^>]*>/).flatten.uniq.sort

        expect(tags_out).to eq(tags_in)
      end
    end

    it 'keeps the words intact through the sanitiser' do
      [described_class::TERMS, described_class::PRE_JOB].each do |html|
        strip_tags_and_space = ->(s) { s.gsub(/<[^>]+>/, '').gsub(/\s+/, ' ').strip }

        expect(strip_tags_and_space.call(clean(html)))
          .to eq(strip_tags_and_space.call(html))
      end
    end

    # Entities and literal characters round-trip differently through the
    # editor, so the defaults stay in the literal form the editor produces.
    it 'uses literal characters rather than HTML entities' do
      [described_class::TERMS, described_class::PRE_JOB].each do |html|
        expect(html).not_to match(/&[a-z]+;/)
      end
    end

    it 'preserves the original terms numbering, which has never had a clause 3' do
      numbers = described_class::TERMS.scan(/<b>(\d+)\./).flatten.map(&:to_i)

      expect(numbers).to eq([1, 2, 4, 5, 6, 7, 8, 9])
    end
  end

  describe 'sanitising user content' do
    it 'strips anything outside the editor’s own tag set' do
      dirty = '<p>Keep <b>bold</b> <i>italic</i> <u>underline</u></p>' \
              '<script>alert(1)</script><img src=x><iframe src="x"></iframe>' \
              '<a href="http://evil.test">link</a>'

      result = clean(dirty)

      expect(result).to include('<b>bold</b>', '<i>italic</i>', '<u>underline</u>')
      expect(result).not_to include('<script', '<img', '<iframe', '<a ')
    end

    it 'strips every attribute, including event handlers and inline styles' do
      result = clean('<p style="color:red" onclick="x()">text</p>')

      expect(result).to eq('<p>text</p>')
    end
  end

  describe '.for' do
    it 'returns the matching document' do
      expect(described_class.for(:terms)).to eq(described_class::TERMS)
      expect(described_class.for(:pre_job)).to eq(described_class::PRE_JOB)
    end

    it 'raises on an unknown key rather than returning empty content' do
      expect { described_class.for(:nope) }.to raise_error(ArgumentError)
    end
  end
end
