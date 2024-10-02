import { Sevenzip } from 'sevenzip';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    Sevenzip.echo({ value: inputValue })
}
