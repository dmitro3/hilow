import {
  useAccount,
  useConnect,
  useDisconnect,
} from 'wagmi'

const Profile: React.FC = () => {
  const { data: account } = useAccount()
  const { connect, connectors, error, isConnecting, pendingConnector } =
    useConnect()
  const { disconnect } = useDisconnect({
    onSuccess(data) {
      console.log('Success', data)
    }, onSettled(data, error) {
      console.log('Settled', { data, error })
    }, onError(error) {
      console.log('Error', error)
    },
  })

  if (account) {
    // @ts-ignore
    return (
      <div>
        <div>
          {account.address}
        </div>
        {/* @ts-ignore */}
        <div>Connected to {account.connector.name}</div>
        {/* @ts-ignore */}
        <button onClick={disconnect}>Disconnect</button>
      </div>
    )
  }

  return (
    <div>
      {connectors.map((connector) => (
        <button
          disabled={!connector.ready}
          key={connector.id}
          onClick={() => connect(connector)}
        >
          {connector.name}
          {!connector.ready && ' (unsupported)'}
          {isConnecting &&
            connector.id === pendingConnector?.id &&
            ' (connecting)'}
        </button>
      ))}

      {error && <div>{error.message}</div>}
    </div>
  )
}

export default Profile;