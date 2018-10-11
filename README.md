# Upload, organize and search for files with tags

## Running locally

After cloning the repository, you should ```cd files/```

Make sure you have ruby 2.3.7 running.

Install dependencies ```bundle install```.

Prepare database ```rake db:migrate```.

Start the server ```bin/rails s```.

Now your app is running in localhost on port 3000.

To run all tests ```rspec -f d```.


## Usage with curl

### Uploading files

```
curl -X POST -u admin:admin  -F 'name=Brazil' -F 'tags[]=country' -F 'tags[]=america' -F 'tags[]=south' -F 'tags[]=portuguese' -F 'file=@./file.txt' -v http://localhost:3000/file
```

### Searching for files

```
curl -X GET -u admin:admin -v http://localhost:3000/files/+country/1
```
