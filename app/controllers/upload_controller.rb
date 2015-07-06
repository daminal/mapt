class UploadController < ApplicationController
  def new
  end

  def create
  end

  def show
  end

  def upload
    uploaded_io = params[upload]
    File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
      file.write(uploaded_io.read)
    end
  end

end
