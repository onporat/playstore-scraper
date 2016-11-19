package main

import (
  "bufio"
  "fmt"
  "os"
  "net/http"
  "io/ioutil"
  "net/url"
)

func check(e error) {
  if e != nil {
    panic(e)
  }
}

func post(id string) {
  resp, err := http.PostForm("http://localhost:8000/write",
  url.Values{"id": {id}})

  if nil != err {
    fmt.Println("errorination happened getting the response", err)
    return
  }

  defer resp.Body.Close()
  ioutil.ReadAll(resp.Body)

}

func main() {
  f, err := os.Open("data/IDs.txt")
  check(err)

  scanner := bufio.NewScanner(f)
  for scanner.Scan() {
    fmt.Println(scanner.Text()) // Println will add back the final '\n'
    post(scanner.Text())
  }
  if err := scanner.Err(); err != nil {
    fmt.Fprintln(os.Stderr, "reading standard input:", err)
  }
}

