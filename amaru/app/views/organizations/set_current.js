var pathname = top.location.pathname;
var newlocation = "/dashboard";
if (/platform/.test(pathname)){
  newlocation = "/platforms";
}
if (/groups/.test(pathname)){
  newlocation = "/groups";
}
if (/organization/.test(pathname)){
  newlocation = "/organizations";
}
if (/tools/.test(pathname)){
  newlocation = "/tools";
}
top.location.replace(newlocation);
