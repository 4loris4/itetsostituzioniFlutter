<?php

function sendPushNotification($to = "", $data = array()) {
    $apiKey = "AIzaSyAcAkZA8e-2nam-wSs7K6uAgidJTh9iVpk";
    $fields = array("to" => $to, "notification" => $data);
    $headers = array("Authorization: key=".$apiKey, "Content-Type: application/json");
    $url = "https://fcm.googleapis.com/fcm/send";

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($fields));
    $result = curl_exec($ch);

    return json_decode($result, true);
}

$n = $_GET["n"];
$to = "/topics/all";
$data = array(
    //'title' => 'title',
    "body" => $_GET["text"]
);
//print_r(sendPushNotification($to,$data));
for($i = 0; $i < $n; $i++) {
    sendPushNotification($to,$data);
}

Header("Location: index.html");

//virtuale
//c3J5PykqIWw:APA91bGwwOR_iavTsypUVc2DMn6euN3VED-9_8Kbl9S_zKSMOt0_V76X0hZ5UbkHYPhsEvl8FuBB5Ot9ykwv6gW7QV_I4_3RXKhuUSsIJiW8Pm66B48Pih7IO4ZrLeDqMQ1cXBIjRutB
//fisico
//dXd12GgFU3U:APA91bFeHypMvCzeGY2p0uqOD0yEyN8Xx_13fcKuWsbSklLUGF_jroG-UvbptKCjUciC_U8gmXlkKFnvlY7pHKNvdWaaH01VeeqobgcAcOFG4jpcucJRVDW64t62-xz3iF0ylbXjyZrF

?>