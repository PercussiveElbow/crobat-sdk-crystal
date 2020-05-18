require "http/client"
require "json"
require "option_parser"

VERSION = "0.1.0"

class CrobatClient

  def initialize(@api_url : String)
    if @api_url.includes?("https://")  && @api_url.includes?("http://")
      raise CrobatInvalidAPIConfigException.new("#{@api_url} is not a valid API")
    end
  end

  def retrieve_all(search_query : String)
    items = query_all_endpoint(search_query,0)
    items.each do | item | 
      puts(item.value)
    end
    items
  end

  def retrieve_tlds(search_query : String)
    items = query_tld_endpoint(search_query,0)
    items.each do | item | 
      puts(item)
    end
    items
  end

  def retrieve_subdomains(domain : String)
    items = query_subdomains_endpoint(domain,0)
    items.each do | item | 
      puts(item)
    end
    items
  end

  def query_all_endpoint(search_query : String, page : Int) : Array(SonarAllResult)
    begin
      page_query = page > 0 ? "?page=#{page.to_s}" : ""
      resp = HTTP::Client.get( "#{@api_url}/all/#{search_query}#{page_query}")
      if resp.status_code == 200
        items = Array(SonarAllResult).from_json(resp.body)
        if items.size()>=999
          recursive_items = query_all_endpoint(search_query,page+1)
          return recursive_items.size()> 0 ? items + recursive_items :  items
        else
          return items
        end
      else
        puts(resp.headers)
        raise CrobatQueryException.new("Error querying ALL API Endpoint #{@api_url} with query #{search_query}. Status code #{resp.status_code}")
        return [] of SonarAllResult
      end
    rescue ex : Exception
      print(ex)
      return [] of SonarAllResult
    end
  end

  def query_tld_endpoint(search_query : String, page : Int) : Array(String)
    begin
      page_query = page > 0 ? "?page=#{page.to_s}" : ""
      resp = HTTP::Client.get("#{@api_url}/tlds/#{search_query}#{page_query}")
      if resp.status_code == 200
        items = Array(String).from_json(resp.body)
        return items.size()>=999 ? items + query_tld_endpoint(search_query,page+1) : items
      else
        raise CrobatQueryException.new("Error querying TLD API Endpoint #{@api_url} with TLD #{search_query}. Status code #{resp.status_code}")
      end
    rescue ex : Exception
      print(ex)
      return [] of String
    end
  end

  def query_subdomains_endpoint(domain : String, page : Int) : Array(String)
    begin
      page_query = page > 0 ? "?page=#{page.to_s}" : ""
      resp = HTTP::Client.get("#{@api_url}/subdomains/#{domain}#{page_query}")
      if resp.status_code == 200
        items = Array(String).from_json(resp.body)
        return items.size()>=999 ? items + query_subdomains_endpoint(domain,page+1) : items
      else
        raise CrobatQueryException.new("Error querying Subdomains API Endpoint #{@api_url} with domain #{domain}. Status code #{resp.status_code}")
      end
    rescue ex : Exception
      print(ex)
      return [] of String
    end
  end

  class SonarAllResult 
    JSON.mapping(
      name: String,
      subdomain: String,
      tld: String,
      value: String,
      type: String
    )
  end

  class CrobatQueryException < Exception
  end
  class CrobatInvalidAPIConfigException < Exception
  end

end

def parse_cli_options
  target = ""
  search_type = ""
  output_format = ""
  output_path = ""

  OptionParser.parse do |parser|
    parser.banner = "Crobat Client.\nUsage: ./crobat.cr [arguments]"
    parser.on("-d DOMAIN", "--domain", "Target domain.") { |domain| target = domain  }
    parser.on("-s TYPE","--type", "Search type. (SUBDOMAIN, ALL, TLD") { |type| search_type = type }
    parser.on("-o FORMAT", "--output format","Output format. (JSON, TXT, CSV)") { |format| output_format = format}
    parser.on("-f FILE", "--file path","Output file.") { |file| output_path = file}
    parser.on("-h", "--help", "Show help.") { puts parser }
    parser.invalid_option do |flag|
      STDERR.puts "#{flag} is not a valid parameter. Check -h for more information"
      STDERR.puts parser
      exit(1)
    end
  end

  if target.size() < 1 || search_type.size() < 1
    puts("No domain and search type supplied. Check -h for help")
    exit(1)
  else
    client = CrobatClient.new("https://sonar.omnisint.io")
    case search_type.downcase
    when "all"
      results = client.retrieve_all(target)
    when "tld"
      results = client.retrieve_tlds(target)
    when "subdomain"
      results = client.retrieve_subdomains(target)
    else
      puts("Invalid search type supplied. Valid search types: SUBDOMAIN, ALL, TLD")
    end
    if results && results.size() > 0 && output_format.size() > 0 && output_path.size() > 0
      output_to_file(results, output_format, output_path,search_type)
    end
  end

end

def output_to_file(results, output_format : String, output_path : String, search_type : String)
  output_file = File.open output_path, "w"

  if results.is_a?(Array(String))
    case output_format.downcase
      when "txt"
        output_txt_or_csv(results, output_path, output_file)
      when "csv"
        output_txt_or_csv(results.insert(0,search_type == "tld" ? "tld" : "subdomain"), output_path, output_file)
      when "json"
        output_file.puts({search_type => results}.to_json.to_s)
      else
        puts("Unable to output file")
    end

  elsif results.is_a?(Array(CrobatClient::SonarAllResult))
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

def output_txt_or_csv(output_results : Array(String), output_path : String, output_file)
  output_results.each do | result |
    output_file.puts(result)
  end
end

parse_cli_options()