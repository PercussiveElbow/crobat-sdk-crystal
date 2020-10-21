require "option_parser"
require "./crobat_sdk"


def output_txt_or_csv(output_results : Array(String), output_path : String, output_file)
  output_results.each do | result |
    output_file.puts(result)
  end
end

def output_to_file(results, output_format : String, output_path : String, search_type : String, query : String)
  output_file = File.open output_path, "w"

  if results.is_a?(Array(String))
    case output_format.downcase
      when "txt"
        output_txt_or_csv(results, output_path, output_file)
      when "csv"
        output_txt_or_csv(results.insert(0,search_type == "tld" ? "tld" : "subdomain"), output_path, output_file)
      when "json"
        output_file.puts({query => results}.to_json.to_s)
      else
        puts("Unable to output file")
    end

  elsif results.is_a?(Hash(String,Array(String)))
    organised_results = [] of String
    results.each_key do | key |
      results[key].each do | value |
        organised_results.push(key + ", " + value)
      end
    end

    case output_format.downcase
      when "txt"
        output_txt_or_csv(organised_results, output_path, output_file)
      when "csv"
        output_txt_or_csv(organised_results.insert(0,"IP, subdomain"), output_path, output_file)
      when "json"
        output_file.puts({query => results}.to_json.to_s)
      else
        puts("Unable to output file")
    end
  elsif results.is_a?(Array(Crobat::CrobatSDK::SonarAllResult))
    organised_results = [] of String
    results.each do | result | 
      organised_results.push(result.name + ", " + result.subdomain + ", " + result.tld  + ", " + result.value + ", " + result.type)
    end

    case output_format.downcase
      when "txt"
        output_txt_or_csv(organised_results, output_path, output_file)
      when "csv"
        output_txt_or_csv(organised_results.insert(0,"name, subdomain, tld, value, type"), output_path, output_file)
      when "json"
        output_file.puts(results.to_json.to_s)
      else
        puts("Unable to output file")
    end
  end

  output_file.close
end

def cli
  target = ""
  search_type = ""
  output_format = ""
  output_path = ""

  OptionParser.parse do |parser|
    parser.banner = "Crobat Client.\nUsage: ./crobat.cr [arguments]"
    parser.on("-q QUERY", "--query", "Domain, IP or IP range to query.") { |query| target = query  }
    parser.on("-s TYPE","--type", "Search type. (SUBDOMAIN, TLD, REVERSE, ALL)") { |type| search_type = type }
    parser.on("-f FORMAT", "--format","File output format. (JSON, TXT, CSV)") { |format| output_format = format}
    parser.on("-o FILE", "--output","File output location.") { |file| output_path = file}
    parser.on("-h", "--help", "Show help.") { puts parser }
  end

  if target.size() < 1 || search_type.size() < 1
    puts("No domain and search type supplied. Check -h for help")
    exit(1)
  else
    client = Crobat::CrobatSDK.new("https://sonar.omnisint.io")
    case search_type.downcase
    when "all"
      results = client.retrieve_all(target)
    when "tld"
      results = client.retrieve_tlds(target)
    when "subdomain"
      results = client.retrieve_subdomains(target)
    when "reverse"
      if target.includes?("/")
        results = client.retrieve_reverse_range(target)
      else 
        results = client.retrieve_reverse(target)
      end
    else
      puts("Invalid search type supplied. Valid search types: SUBDOMAIN, ALL, TLD")
    end

    if results
      results.each do | result |
        puts(result.to_s)
      end

      if output_format.size() > 0 && output_path.size() > 0
        output_to_file(results, output_format, output_path, search_type, target)
      end
    end

  end

end

cli()
