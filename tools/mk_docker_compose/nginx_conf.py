nginx_vhost = """
server {{
    listen {port};
    server_name localhost;

    root {nginx_www};
    index index.php index.html;

    location / {{
        try_files $uri $uri/ /index.php?$args;
    }}

    location ~ \.php(/|$) {{
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        set $path_info $fastcgi_path_info;
        try_files $fastcgi_script_name $fastcgi_script_name/;
        include fastcgi_params;
        fastcgi_pass {service_name}:9000;
        fastcgi_param PATH_INFO $path_info;
        fastcgi_param SCRIPT_FILENAME /var/www/html$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT $realpath_root;
    }}
}}
"""