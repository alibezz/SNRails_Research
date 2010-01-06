namespace :todo do
  desc "lists all TODO and FIXME comments in the source code"
  task :all do
    sh 'grep "TODO\|FIXME" -r --exclude ".*" --exclude "*todo.rake" -n app lib vendor/plugins/ | sed -e "s/^[^:]\+:[0-9]\+:/=============================\n&\n/"'
  end

  desc "lists application TODO and FIXME comments in the source code"
  task :app do
    sh 'grep "TODO\|FIXME" -r --exclude ".*" --exclude "*todo.rake" -n app lib | sed -e "s/^[^:]\+:[0-9]\+:/=============================\n&\n/"'
  end

  desc "lists plugins TODO and FIXME comments in the source code"
  task :plugins do
    sh 'grep "TODO\|FIXME" -r --exclude ".*" --exclude "*todo.rake" -n vendor/plugins/ | sed -e "s/^[^:]\+:[0-9]\+:/=============================\n&\n/"'
  end

end
