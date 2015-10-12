#!/usr/bin/env ruby

require 'json'
require 'net/http'

# Downloads directory
downloadDirectory = "/mnt/raid/raidStorage/tcms"

# JSON data
dataURL = "http://listenagainproxy.geronimo.thisisglobal.com/api/Channels/bb138aef-4054-456b-8f37-2d07280dce65%7C8993e4cc-c740-4521-bf16-dbb8240b0dd7/Episodes"
# Audio files
audioDomain = "http://fs.geronimo.thisisglobal.com"
audioBaseURL = "/audio"

resp = Net::HTTP.get_response(URI.parse(dataURL))
episodes = JSON.parse(resp.body)

episodeInfo = episodes.map do |ep|
  {
    date: ep["StartDate"],
    filename: ep["MediaFiles"].first["FileName"]
  }
end


# Check which files are already downloaded
previouslyDownloaded = Dir[downloadDirectory + "/*.mp4"].map { |file| File.basename(file, ".mp4") }

# Download new files
episodeInfo.each do |ep|
  if !previouslyDownloaded.include? ep[:date]
    # Need to download the new file
    Net::HTTP.start(audioDomain) do |http|
      p "Downloading #{ep[:date]}"
      f = open(downloadDirectory + "/" + ep[:date] + ".mp4")
      begin
        http.request_get("audioBaseURL" + ep[:filename]) do |resp|
          resp.read_body do |segment|
            f.write(segment)
          end
        end
      ensure
        f.close()
      end
    end
  end
end
