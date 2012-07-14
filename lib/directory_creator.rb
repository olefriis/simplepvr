class DirectoryCreator
  def self.create_for_show(show_name)
    base_directory_for_show = "recordings/#{show_name}"
    new_sequence_number = Dir.exists?(base_directory_for_show) ? find_new_sequence_number_for(base_directory_for_show) : 1
    new_directory_name = "#{base_directory_for_show}/#{new_sequence_number}"
    FileUtils.makedirs(new_directory_name)
    new_directory_name
  end
  
  private
  def self.find_new_sequence_number_for(base_directory)
    largest_current_sequence_number = Dir.new(base_directory).map {|dir_name| dir_name.to_i }.max
    1 + largest_current_sequence_number
  end
end