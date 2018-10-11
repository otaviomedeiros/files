require 'rails_helper'

RSpec.describe Tag, type: :model do

  describe '.all_tags_associated_with_matching_files(positive_tags, negative_tags)' do
    let!(:united_states) do
      UserFile.create!(name: 'United States') do |uf|
        uf.tags.build(name: 'country')
        uf.tags.build(name: 'america')
        uf.tags.build(name: 'north')
        uf.tags.build(name: 'english')
      end
    end

    let!(:costa_rica) do
      UserFile.create!(name: 'Costa Rica') do |uf|
        uf.tags.build(name: 'country')
        uf.tags.build(name: 'america')
        uf.tags.build(name: 'central')
        uf.tags.build(name: 'spanish')
      end
    end

  describe 'when searching for tags of all available countries in america'
    before { @found_tags = Tag.all_tags_associated_with_matching_files(['country', 'america'], []) }

    def find_tag(name)
      @found_tags.select{|tag| tag.name.eql?(name)}.first
    end

    it { expect(find_tag('country').count).to eq(2) }
    it { expect(find_tag('america').count).to eq(2) }
    it { expect(find_tag('north').count).to eq(1) }
    it { expect(find_tag('central').count).to eq(1) }
  end

end
