copy_file 'app/assets/stylesheets/application.sass'
remove_file 'app/assets/stylesheets/application.css'

copy_file 'app/views/layouts/application.html.slim'
remove_file 'app/views/layouts/application.html.erb'

copy_file 'app/views/layouts/_meta.html.slim'
