require 'colored'
require_relative 'phone_number'
require_relative "email"

module Tact
  class Contact
    attr_reader :id
    attr_accessor :index, :first_name, :last_name

    @@db = Database.new.db

    def self.from_hash(hash, index=nil)
      contact = self.new(hash["first_name"], hash["last_name"], hash["id"], index)
    end

    def self.all
      contact_hashes = @@db.execute("select * from contacts order by last_name asc, first_name asc;")
      contact_hashes.each_with_index.map {|c_hash, index| self.from_hash(c_hash, index + 1) }
    end

    def self.find_by_id(id)
      contact_hashes = @@db.execute("select * from contacts where id = ?", [id])
      self.from_hash(contact_hashes[0]) if !contact_hashes.empty?
    end

    def self.find_by_first_name(first_name)
      results = @@db.execute("select * from contacts where upper(first_name) = upper(?);", [first_name])
      results.map {|c_hash| Contact.from_hash(c_hash) }
    end

    def self.find_by_last_name(last_name)
      results = @@db.execute("select * from contacts where upper(last_name) = upper(?);", [last_name])
    end

    def self.delete(id)
      @@db.execute("delete from contacts where id = ?;", [id]) ? true : false
    end

    def initialize(first_name, last_name, primary_key=nil, index=nil)
      @id = primary_key
      @index = index
      @first_name = first_name.downcase.capitalize
      @last_name = last_name.downcase.capitalize
    end

    def save
      begin
        if @id == nil
          if @@db.execute("insert into contacts (first_name, last_name) values (?, ?);", [@first_name, @last_name])
            @id = @@db.execute("select last_insert_rowid()")[0]["last_insert_rowid()"]
            self
          else
            false
          end
        else
          @@db.execute("update contacts set first_name = ?, last_name = ? where id = ?;", [@first_name, @last_name, @id]) ? self : false
        end
      rescue
        puts "Error: Contact already exists".red 
      end
    end

    def phone_numbers
      number_hashes = @@db.execute("select * from phone_numbers where contact_id = ? order by type asc;", [@id])
      phone_numbers = number_hashes.each_with_index.map do |n_hash, index| 
        PhoneNumber.from_hash(n_hash, index + 1)
      end
      phone_numbers
    end

    def emails
      email_hashes = @@db.execute("select * from emails where contact_id = ?", [@id])
      emails = email_hashes.each_with_index.map do |e_hash, index| 
        Email.from_hash(e_hash, index + 1)
      end
      emails
    end

    def full_name
      first_name + " " + last_name
    end

    def to_s
      string = ""
      string += "[#{index}]".red + " #{full_name}\n".green.bold
    end
  end
end