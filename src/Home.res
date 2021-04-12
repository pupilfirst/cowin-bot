let str = React.string
let logo: string = %bs.raw(`require("./assets/rescript-logo.png")`)

@react.component
let make = () => <div className=""> <Chat__Root /> </div>
