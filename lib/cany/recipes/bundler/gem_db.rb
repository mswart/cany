class Cany::Recipes::Bundler
  Gem.specify :charlock_holmes do
    depend 'libicu-dev', situation: :build
    depend 'libicu48', situation: :runtime
  end

  Gem.specify :ethon do
    depend 'libcurl3', situation: [:build, :runtime]
  end

  Gem.specify :mysql2 do
    depend 'libmysqlclient-dev', situation: :build
    depend 'libmysqlclient18', situation: :runtime
  end

  Gem.specify :nokogiri do
    depend 'libxml2-dev', situation: :build
    depend 'libxml2', situation: :runtime
    depend 'libxslt1-dev', situation: :build
    depend 'libxslt1.1', situation: :runtime
  end

  Gem.specify :pg do
    depend 'libpq-dev', situation: :build
    depend 'libpq5', situation: :runtime
  end

  Gem.specify :rmagick do
    depend 'libmagickcore-dev', situation: :build
    depend 'libmagickwand-dev', situation: :build
  end
end
