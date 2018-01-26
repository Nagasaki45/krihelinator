docker-compose build www
docker tag krihelinator_www nagasaki45/krihelinator_www
docker push nagasaki45/krihelinator_www

scp docker-compose.yml krihelinator.xyz:krihelinator/
scp docker-compose.prod.yml krihelinator.xyz:krihelinator/
scp -r secrets krihelinator.xyz:krihelinator/

ssh krihelinator.xyz << EOF
  cd krihelinator
  docker-compose -f docker-compose.yml -f docker-compose.prod.yml pull
  docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
EOF
