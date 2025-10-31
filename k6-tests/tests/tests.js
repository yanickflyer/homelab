import { check } from 'k6';
import http from 'k6/http';

export let options = {
    // Define the total number of Virtual Users you want across ALL 10 pods
    vus: 10, 
    // Define the total duration of the test
    duration: '5s', 
};

export default function () {
    const res = http.get('https://sretech.org/');
    check(res, {
        'is status 200': (r) => r.status === 200,
    });
}