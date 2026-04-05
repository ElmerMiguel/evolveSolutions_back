const response = await fetch("http://localhost:3000/auth/register", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    username: "ttta1",
    email: "ttta1@ttt.com",
    password: "p",
    firstName: "t",
    lastName: "t",
    photoUrl: ""
  })
});

const body = await response.text();
console.log("STATUS:", response.status);
console.log("BODY:", body);
