require 'net/http'
require 'nokogiri'
require 'sinatra'

def get_dining_data(year, month, day, location_num)
  uri = URI('http://nutrition.sa.ucsc.edu/menuSamp.asp')
  uri.query = URI.encode_www_form(
    myaction: 'read',
    dtdate: "#{month}/#{day}/#{year}",
    locationNum: location_num
  )

  res = Net::HTTP.get(uri)
  # TODO: check that above succeeded

  doc = Nokogiri::HTML(res)
  food_items = doc.css('div.menusamprecipes')
end

#Cowell/Stevenson -> 05, Cowell
#Crown/Merrill -> 20, Crown Merrill
#Porter/Kresge -> 25, Porter
#Rachel Carson/Oakes -> 30, Rachel Carson Oakes Dining Hall
#9/10 -> 40, College Nine Ten

get '/' do
  colleges = {"Cowell/Stevenson" => "05", "Crown/Merrill" => "20", "Porter" => "25", "Rachel Carson/Oakes" => "30", "Nine/Ten" => "40"}
  colleges_with_mac_and_cheese = []

  date = Time.now.to_s.split(' ')[0].split('-')
  year = date[0]
  month = date[1]
  day = date[2]
  # year = "2017"
  # month = "1"
  # day = "7"

  colleges.each do |hall, num|
    food_items = get_dining_data(year, month, day, num)
    food_items.each do |item|
      if item.text == "Macaroni & Cheese"
        colleges_with_mac_and_cheese.push(hall)
      end
    end
  end

  erb :index, :locals => {:college_list => colleges_with_mac_and_cheese}
end
