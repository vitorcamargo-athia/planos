export default function call(method, body = {}, callback = () => { }) {
  let apiKey = 'e949f8ee3299e48ed653375016868b9b6d7a2c7b0619127ccebaa9766ee9ab56';

  fetch('https:/portal.athia.com.br/app/planos.php' + method, { method: body == {

    } ? 'GET' : 'POST', body: body })
    .then(rs => rs.json())
    .then(rs => callback(rs));
}

