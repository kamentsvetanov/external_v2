function density = asNormal(obj)

d = rows(obj.h);
density = normal_density(obj.mean, obj.h*obj.h' + obj.v*eye(d));
