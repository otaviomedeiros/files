require 'rails_helper'

RSpec.describe UserFile, type: :model do

  describe '.create_file_with_tags(params)' do
    context 'when there are no tags called country or america' do
      it 'creates a new file with new tags' do
        user_file = UserFile.create_file_with_tags(name: 'United States', tags: ['country', 'america'])

        expect(user_file.name).to eq('United States')
        expect(user_file.tags.map(&:name)).to eq(['country', 'america'])
      end
    end

    context 'when there is a tag called america in database' do
      before { Tag.create(name: 'america') }

      it 'creates a new file poiting to existent tag' do
        user_file = UserFile.create_file_with_tags(name: 'United States', tags: ['country', 'america'])

        expect(user_file.name).to eq('United States')
        expect(user_file.tags.map(&:name)).to eq(['country', 'america'])
        expect(Tag.count).to eq(2)
      end
    end
  end

  describe '.tag_search_query(positive_tags, negative_tags)' do
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

    let!(:argentina) do
      UserFile.create!(name: 'Argentina') do |uf|
        uf.tags.build(name: 'country')
        uf.tags.build(name: 'america')
        uf.tags.build(name: 'south')
        uf.tags.build(name: 'spanish')
      end
    end

    let!(:brazil) do
      UserFile.create!(name: 'Brazil') do |uf|
        uf.tags.build(name: 'country')
        uf.tags.build(name: 'america')
        uf.tags.build(name: 'south')
        uf.tags.build(name: 'portuguese')
      end
    end

    it 'returns all available countries in america' do
      countries = UserFile.tag_search_query(['country', 'america'], [])
      expect(countries.map(&:name)).to eq(['United States', 'Costa Rica', 'Argentina', 'Brazil'])
    end

    it 'returns all available countries in europe' do
      countries = UserFile.tag_search_query(['country', 'europe'], [])
      expect(countries).to be_empty
    end

    it 'returns all available countries in america which speak spanish' do
      countries = UserFile.tag_search_query(['country', 'america', 'spanish'], [])
      expect(countries.map(&:name)).to eq(['Costa Rica', 'Argentina'])
    end

    it 'returns all available countries in america which is not from north' do
      countries = UserFile.tag_search_query(['country', 'america'], ['north'])
      expect(countries.map(&:name)).to eq(['Costa Rica', 'Argentina', 'Brazil'])
    end

    it 'returns all available countries in america which dont speak spanish' do
      countries = UserFile.tag_search_query(['country', 'america'], ['spanish'])
      expect(countries.map(&:name)).to eq(['United States', 'Brazil'])
    end

    it 'returns all available countries in america which dont speak spanish or english' do
      countries = UserFile.tag_search_query(['country', 'america'], ['spanish', 'english'])
      expect(countries.map(&:name)).to eq(['Brazil'])
    end
  end

end
