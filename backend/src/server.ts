import app from "./app.js";

const PORT = 3000;

app.listen(PORT, () => {
  console.log(`Dear Stranger server is running on port ${PORT}`);
});