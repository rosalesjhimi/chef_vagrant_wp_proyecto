# Instalar WP CLI
remote_file '/tmp/wp' do
  source 'https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# Mover WP CLI a /bin
execute 'Move WP CLI' do
  command 'mv /tmp/wp /bin/wp'
  not_if { ::File.exist?('/bin/wp') }
end

# Hacer WP CLI ejecutable
file '/bin/wp' do
  mode '0755'
end

# Instalar WordPress y configurar
execute 'Finish Wordpress installation' do
  command 'sudo -u vagrant -i -- wp core install --path=/opt/wordpress/ --url=localhost --title="EPNEWMAN - Herramientas de automatización de despliegues - Jhimi Rosales" --admin_user=admin --admin_password="Epnewman123" --admin_email=admin@epnewman.edu.pe'
  not_if 'wp core is-installed', environment: { 'PATH' => '/bin:/usr/bin:/usr/local/bin' }
end

# Descargar el archivo ZIP del tema Blogmate
remote_file '/tmp/blogmate.zip' do
  source 'https://downloads.wordpress.org/theme/blogmate.1.0.10.zip'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

# Cambia la propiedad del directorio y sub directorio a vagrant
execute 'Cambia la propiedad del directorio y sub directorio a vagrant' do
  command 'sudo chown -R vagrant:vagrant /opt/wordpress/wp-content'
  action :run
end

# Asegurarse de que el directorio wp-content es escribible
execute 'Ensure wp-content directory is writable' do
  command 'sudo chmod -R 755 /opt/wordpress/wp-content/'
  action :run
end

# Verificar si el archivo ZIP del tema Blogmate existe
execute 'Permiso de lectura del archivo' do
  command 'sudo chmod 644 /tmp/blogmate.zip'
  action :run
end

# Instalar el tema Blogmate desde el archivo ZIP
execute 'Install Blogmate Theme' do
  command 'sudo -u vagrant -i -- wp theme install /tmp/blogmate.zip --path=/opt/wordpress/'
  not_if 'wp theme is-installed blogmate', environment: { 'PATH' => '/bin:/usr/bin:/usr/local/bin' }
end

# Activar el tema Blogmate
execute 'Activate Blogmate Theme' do
  command 'sudo -u vagrant -i -- wp theme activate blogmate --path=/opt/wordpress/'
  not_if 'wp theme status | grep -q "blogmate"', environment: { 'PATH' => '/bin:/usr/bin:/usr/local/bin' }
end
