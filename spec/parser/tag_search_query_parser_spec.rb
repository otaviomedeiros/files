require 'rails_helper'

RSpec.describe TagSearchQueryParser do

  it 'parses query with only one positive tag' do
    parser = TagSearchQueryParser.new('+america')
    tags = parser.parse

    expect(tags[:+]).to eq(['america'])
    expect(tags[:-]).to be_empty
  end

  it 'parses query with only one negative tag' do
    parser = TagSearchQueryParser.new('-america')
    tags = parser.parse

    expect(tags[:+]).to be_empty
    expect(tags[:-]).to eq(['america'])
  end

  it 'parses complex query' do
    parser = TagSearchQueryParser.new('+america +english -portuguese -spanish')
    tags = parser.parse

    expect(tags[:+]).to eq(['america', 'english'])
    expect(tags[:-]).to eq(['portuguese', 'spanish'])
  end

  it 'ignores tags with no sign' do
    parser = TagSearchQueryParser.new('+america +south america +english -portuguese -spanish')
    tags = parser.parse

    expect(tags[:+]).to eq(['america', 'south', 'english'])
    expect(tags[:-]).to eq(['portuguese', 'spanish'])
  end
  
end
