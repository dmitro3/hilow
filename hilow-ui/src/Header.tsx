import React from "react";
import { Box, Stack, Flex, Button } from "@chakra-ui/react";
import { useAccount, useDisconnect } from "wagmi";

const Header: React.FC = () => {
  const { data: accountData } = useAccount();
  const { disconnect } = useDisconnect();

  return (
    <Flex
      as="nav"
      align="center"
      justify="space-between"
      wrap="wrap"
      padding={6}
      bg="whitesmoke"
      color="black"
    >
      <Stack
        direction={{ base: "column", md: "row" }}
        display="flex"
        width={{ base: "full", md: "auto" }}
        alignItems="center"
        flexGrow={1}
        mt={{ base: 4, md: 0 }}
      ></Stack>

      <Box display="block" mt={{ base: 4, md: 0 }}>
        <Button
          variant="outline"
          _hover={{ bg: "black", borderColor: "black", color: "white" }}
          onClick={() => disconnect()}
        >
          {accountData?.address} - Disconnect
        </Button>
      </Box>
    </Flex>
  );
};

export default Header;
