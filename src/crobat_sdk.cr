require "http/client"
require "json"

module Crobat
    class CrobatSDK

        def initialize(@api_url : String)
            if @api_url.includes?("https://")  && @api_url.includes?("http://")
                raise CrobatInvalidAPIConfigException.new("#{@api_url} is not a valid API")
            end
        end
    
        def retrieve_subdomains(domain : String, page : Int = 0) : Array(String)
            begin
                page_query = page > 0 ? "?page=#{page.to_s}" : ""
                resp = HTTP::Client.get("#{@api_url}/subdomains/#{domain}#{page_query}")
                if resp.status_code == 200
                    items = Array(String).from_json(resp.body)
                    return items.size()>=999 ? items + retrieve_subdomains(domain,page+1) : items
                else
                    raise CrobatQueryException.new("Error querying Subdomains API Endpoint #{@api_url} with domain #{domain}. Status code #{resp.status_code}")
                end
            rescue ex : Exception
                print(ex)
                return [] of String
            end
        end
    
        def retrieve_tlds(search_query : String, page : Int = 0) : Array(String)
            begin
                page_query = page > 0 ? "?page=#{page.to_s}" : ""
                resp = HTTP::Client.get("#{@api_url}/tlds/#{search_query}#{page_query}")
                if resp.status_code == 200
                    items = Array(String).from_json(resp.body)
                    return items.size()>=999 ? items + retrieve_tlds(search_query,page+1) : items
                else
                    raise CrobatQueryException.new("Error querying TLD API Endpoint #{@api_url} with TLD #{search_query}. Status code #{resp.status_code}")
                end
            rescue ex : Exception
                print(ex)
                return [] of String
            end
        end
    
        def retrieve_all(search_query : String, page : Int = 0) : Array(SonarAllResult)
            begin
                page_query = page > 0 ? "?page=#{page.to_s}" : ""
                resp = HTTP::Client.get( "#{@api_url}/all/#{search_query}#{page_query}")
                if resp.status_code == 200
                    items = Array(SonarAllResult).from_json(resp.body)
                    if items.size()>=999
                        recursive_items = retrieve_all(search_query,page+1)
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
    
        class SonarAllResult include JSON::Serializable 
            property name : String
            property subdomain : String
            property tld : String
            property value : String
            property type : String
    
            def to_s
                "#{self.name} #{self.subdomain} #{self.tld} #{self.value} #{self.type}"
            end
        end
    
        class CrobatQueryException < Exception
        end
        class CrobatInvalidAPIConfigException < Exception
        end
    end
end