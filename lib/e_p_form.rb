require 'rubygems'
require 'mechanize'
require 'active_record'
require_relative 'e_p_form_category'

class EPForm
  attr_accessor :categories, :id
  
  def initialize id, page
    
    @categories = []
    @id = id
    
    
    ####### CATEGORY General ########    
    category = EPFormCategory.new('General')
    @categories << category
    if page.search("div[@class='right-content box']/table/tr[@valign='top']//font[@color='green']/b").xpath("text()").to_s.strip.eql? "Global Internship"
      category.entries['Exchange program'] = 1
    else
      category.entries['Exchange program'] = 2
    end  
    langlevel_code = -1
    page.search("div[@class='left-content box']/table/tr/td").each do |td|
      text = td.xpath("text()").to_s.strip
      unless text.empty?
        if td.has_attribute? 'class'
          puts text
          case text
          when "Basic"
            langlevel_code = 1
          when "Good"
            langlevel_code = 2
          when "Excellent"
            langlevel_code = 3
          when "Native"
            langlevel_code = 4
          end
          if langlevel_code < 0
            category = EPFormCategory.new(text)
          else
            category = EPFormCategory.new("Languages")
          end
          @categories << category
        else
          puts "\t" + text
          praxis_code = -1
          unless text.index("(Academic)").nil?
            praxis_code = 1
            text.slice! "(Academic)"
          else
            unless text.index("(Both)").nil?
              praxis_code = 3
              text.slice! "(Both)"
            else
              unless text.index("(Working)").nil?
                praxis_code = 2
                text.slice! "(Working)"
              end
            end
          end

          if praxis_code < 0
            if langlevel_code < 0
              category.entries[text] = 1
            else
              category.entries[text] = langlevel_code
            end
          else
            category.entries[text] = praxis_code
          end
        end
      end
    end
#    page.search("div[@class='left-content box']//td").each do |td|
#      text = td.xpath("text()").to_s.strip
#      if text.eql? "Internship Earliest Start Date"
#        puts text
#      end
#    end
  end
  
  def serialize available_cols, connection
    
    # populate categories and temporary maps
    cols_categories_map = {}
    escaped_cols_values_map = {}
    escaped_cols_cols_map = {}
    @categories.each do |category|
      connection.execute("INSERT IGNORE INTO `categories` (`name`) VALUES (#{ActiveRecord::Base.sanitize(category.name)});")
      category_id = connection.execute("SELECT `id` FROM `categories` WHERE name=#{ActiveRecord::Base.sanitize(category.name)}").first[0]
      category.entries.each do |entry, value|
        cols_categories_map[entry.escape_col_name] = category_id
        escaped_cols_values_map[entry.escape_col_name] = value
        escaped_cols_cols_map[entry.escape_col_name] = entry
      end
    end
    
    # handle missing cols
    missing_cols = escaped_cols_values_map.keys-available_cols
    missing_cols.each do |missing_col|
      connection.execute("ALTER TABLE `ep_forms` ADD COLUMN `#{missing_col}` TINYINT UNSIGNED NOT NULL DEFAULT '0' AFTER `id`;")
      connection.execute("INSERT INTO `skills` (`code`, `name`, `category_id`) VALUES ('#{missing_col}', #{ActiveRecord::Base.sanitize(escaped_cols_cols_map[missing_col])}, #{cols_categories_map[missing_col]});")
    end
    
    # insert ep form
    col_string = 'id'
    value_string = @id
    escaped_cols_values_map.each do |col, value|
      col_string += ", `#{col}`"
      value_string += ", #{value}"
    end
    connection.execute("INSERT IGNORE INTO `ep_forms` (#{col_string}) VALUES (#{value_string});")
    
    return available_cols+missing_cols
    
#      tabled_skills = skills_in_table
#      
#      @categories.each do |category|
#        # insert category if not exists
#        connection.execute("INSERT IGNORE INTO `categories` (`name`) VALUES (#{ActiveRecord::Base.sanitize(category.name)});")
#        category_id = connection.execute("SELECT id FROM categories WHERE name=#{ActiveRecord::Base.sanitize(category.name)}").first[0]
#        
#        entries_name_map = {}
#        category.entries.each { |entry, value| entries_name_map[entry.escape_col_name] = value }
#        missing_skills = (entries_name_map.keys-tabled_skills).uniq
#        missing_skills.each do |skill_serialized|
#          if connection.column_exists? "ep_forms", skill_serialized
#            connection.execute("ALTER TABLE `ep_forms` ADD COLUMN `#{skill_serialized}` TINYINT UNSIGNED NOT NULL DEFAULT '0' AFTER `id`;")
#            connection.flush
#          end
#          connection.execute("INSERT INTO `skills` (`code`, `name`, `category_id`) VALUES ('#{skill_serialized}', #{ActiveRecord::Base.sanitize(entries_name_map[skill_serialized])}, #{category_id});")
#        end
#        tabled_skills += missing_skills
#        
#        colums_sql_string = "`id`"
#        data_sql_string = @id.to_s
#        category.entries.each {|entry, value| colums_sql_string += ", `#{entry.escape_col_name}`"; data_sql_string += ", #{value}" }
#        connection.execute("INSERT IGNORE INTO `ep_forms` (#{colums_sql_string}) VALUES (#{data_sql_string});")
#        
#      end
  end
  String.class_eval do
    def escape_col_name 
      gsub(/[^a-zA-Z0-9]/, "_").downcase
    end
  end
end
