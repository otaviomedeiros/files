require 'rails_helper'

describe 'Files API', type: :request do
  describe 'POST /file' do
    context 'with invalid credentials' do
      let(:invalid_credentials) { { 'HTTP_AUTHORIZATION': ActionController::HttpAuthentication::Basic.encode_credentials('admin', '') } }

      it 'returns status code 401' do
        post '/file', headers: invalid_credentials
        expect(response).to have_http_status(401)
      end
    end

    context 'with correct credentials' do
      let(:valid_credentials) { { 'HTTP_AUTHORIZATION': ActionController::HttpAuthentication::Basic.encode_credentials('admin', 'admin') } }
      let(:file) { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/file.txt'))) }

      it 'creates a new file with tags associated with it' do
        post '/file', params: { name: 'United States', tags: ['america', 'english'], file: file }, headers: valid_credentials
        json = JSON.parse(response.body)

        expect(json['url']).to match(/http:\/\/attachmentsdomain\.com/)
        expect(json['url']).to match(/file\.txt/)
      end
    end

    context 'with invalid data' do
      let(:valid_credentials) { { 'HTTP_AUTHORIZATION': ActionController::HttpAuthentication::Basic.encode_credentials('admin', 'admin') } }

      it 'returns status code 400' do
        post '/file', params: {}, headers: valid_credentials
        expect(response).to have_http_status(400)
      end
    end
  end

  describe 'GET /files/:tag_search_query/:page' do
    context 'with invalid credentials' do
      let(:invalid_credentials) { { 'HTTP_AUTHORIZATION': ActionController::HttpAuthentication::Basic.encode_credentials('admin', '') } }

      it 'returns status code 401' do
        get '/files/+america/1', headers: invalid_credentials
        expect(response).to have_http_status(401)
      end
    end

    context 'with correct credentials' do
      let(:valid_credentials) { { 'HTTP_AUTHORIZATION': ActionController::HttpAuthentication::Basic.encode_credentials('admin', 'admin') } }

      before do
        ['United States', 'Canada'].each do |country|
          UserFile.create!(name: country) do |uf|
            uf.tags.build(name: 'america')
            uf.tags.build(name: 'country')
          end
        end

        UserFile.create!(name: 'England') do |uf|
          uf.tags.build(name: 'europe')
          uf.tags.build(name: 'country')
        end
      end

      it 'returns files that match the query' do
        get '/files/+america/1', headers: valid_credentials
        json = JSON.parse(response.body)

        expect(json['total_records']).to eq(2)
        expect(json['related_tags']).to eq([
          {"tag"=>"america", "file_count"=>2},
          {"file_count"=>2, "tag"=>"country"}
        ])
        expect(json['records'].map{|record| record['name']}).to eq(['United States', 'Canada'])
      end

      it 'returns status code 200' do
        get '/files/+america/1', headers: valid_credentials
        expect(response).to have_http_status(200)
      end

      it 'returns correct files for page 1 and limit 2' do
        get '/files/+country/1', headers: valid_credentials, params: { limit: 2 }
        json = JSON.parse(response.body)

        expect(json['total_records']).to eq(3)
        expect(json['related_tags']).to eq([
          {"file_count"=>2, "tag"=>"america"},
          {"file_count"=>3, "tag"=>"country"},
          {"file_count"=>1, "tag"=>"europe"}
        ])
        expect(json['records'].map{|record| record['name']}).to eq(['United States', 'Canada'])
      end

      it 'returns correct files for page 2  and limit 2' do
        get '/files/+country/2', headers: valid_credentials, params: { limit: 2 }
        json = JSON.parse(response.body)

        expect(json['total_records']).to eq(3)
        expect(json['related_tags']).to eq([
          {"file_count"=>2, "tag"=>"america"},
          {"file_count"=>3, "tag"=>"country"},
          {"file_count"=>1, "tag"=>"europe"}
        ])
        expect(json['records'].map{|record| record['name']}).to eq(['England'])
      end
    end
  end
end
