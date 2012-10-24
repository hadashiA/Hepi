# coding: utf-8

dir './'

font 'misaki_gothic.ttf', :size => 10.pt do 
  '広奈さんお誕生日おめでとう'.each_char do |char|
    "#{char}.png" << char
  end
end

