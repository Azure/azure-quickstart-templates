<?php
$servers = "{COMMA_DELIMITED_SERVERS_LIST}";
$serversArray = explode(",",$servers);

print("Memcached servers: ".implode(", ",$serversArray)."<br>");

$mem = new Memcached();

for ($i=0; $i<sizeof($serversArray); $i++)
{
	$mem->addServer($serversArray[$i], 11211);
}

$result = $mem->get("key1");

$date = date("Y-m-d G:i");
print("Today's date ".$date."<br>");

if ($result) {
	echo $result;
} else {
	echo "No matching key found. It will be added now.";
	$mem->set("key1","This is the data in the key added on ".$date) or die("Could not save");
}

print("<div><b>memcached stats</b><br>");
print_r($mem->getStats());
print("</div>");

?>